#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <dlfcn.h>
#include <sys/stat.h>

int otel_span_start(FILE *sdk, const char *type, const char *name) {
  size_t buffer_size = 1024 * 4;
  char *buffer = (char*) calloc(buffer_size, sizeof(char));
  if (!buffer) return -1;

  char *sdk_response = tmpnam(NULL); // this is unsafe, i know
  if (mkfifo(sdk_response, 0666) != 0) { free(buffer); return -1; }

  memset(buffer, 0, buffer_size);
  sprintf(buffer, "SPAN_START %s %s %s %s %s %s\n", sdk_response, getenv("TRACEPARENT"), getenv("TRACESTATE"), "auto", type, name);
  fwrite(buffer, sizeof(char), strlen(buffer), sdk);
  fflush(sdk);

  memset(buffer, 0, buffer_size);
  int response_file = open(sdk_response, O_RDONLY);
  read(response_file, buffer, buffer_size);
  close(response_file);
  int span_handle = atoi(buffer);

  remove(sdk_response);
  free(buffer);
  return span_handle;
}

char * otel_traceparent(FILE *sdk, int span_handle) {
  size_t buffer_size = 1024 * 4;
  char *buffer = (char*) calloc(buffer_size, sizeof(char));
  if (!buffer) return NULL;

  char *sdk_response = tmpnam(NULL); // this is unsafe, i know
  if (mkfifo(sdk_response, 0666) != 0) { free(buffer); return NULL; }

  memset(buffer, 0, buffer_size);
  sprintf(buffer, "SPAN_TRACEPARENT %s %d\n", sdk_response, span_handle);
  fwrite(buffer, sizeof(char), strlen(buffer), sdk);
  fflush(sdk);

  memset(buffer, 0, buffer_size);
  int response_file = open(sdk_response, O_RDONLY);
  read(response_file, buffer, buffer_size);
  close(response_file);

  remove(sdk_response);
  return buffer;
}

int inject(char *buffer, size_t length) {
  if (length == 24 && strcmp(buffer, "PRI * HTTP/2.0\r\n\r\nSM\r\n") == 0) {
    return 1;
  }
  char *line_end = strchr(buffer, '\n');
  if (!line_end) {
    return 2;
  }
  *line_end = '\0';
  if (!strstr(buffer, " HTTP/")) {
    *line_end = '\n';
    return 3;
  }
  *line_end = '\n';

  buffer = line_end + 1;
  line_end = strchr(buffer, '\n');
  while (!!line_end && line_end - buffer > 1) {
    *line_end = '\0';
    if (strstr(buffer, "traceparent: ") == buffer && !!strstr(buffer, getenv("TRACEPARENT"))) {
      FILE *sdk = fopen(getenv("OTEL_SHELL_INJECT_HTTP_SDK_PIPE"), "a+");
      if (!sdk) return 4;
      int span_handle = otel_span_start(sdk, "CLIENT", "HTTP");
      if (span_handle < 0) return 5;
      for (int i = 0; i < 1000 && access(getenv("OTEL_SHELL_INJECT_HTTP_HANDLE_FILE"), F_OK) == 0; i++) usleep(10 * 1000);
      {
        char span_handle_string[16];
        memset(span_handle_string, 0, 16);
        sprintf(span_handle_string, "%d", span_handle);
        FILE *storage = fopen(getenv("OTEL_SHELL_INJECT_HTTP_HANDLE_FILE"), "w");
        if (!storage) return 6;
        fwrite(span_handle_string, sizeof(char), strlen(span_handle_string), storage); // TODO this could fail, what then?
        fclose(storage);
      }
      char *traceparent = otel_traceparent(sdk, span_handle);
      if (!traceparent) return 7;
      if (strlen("traceparent: ") + strlen(traceparent) + 1 != strlen(buffer)) { free(traceparent); return 8; }
      sprintf(buffer, "traceparent: %s\r", traceparent);
      free(traceparent);
      fclose(sdk); // this will leak on some early aborts, process terminate will clean it up
      *line_end = '\n';
      return 0;
    }
    *line_end = '\n';
    buffer = line_end + 1;
    line_end = strchr(buffer, '\n');
  }

  return 9;
}

int inject_safely(char *buffer, size_t length) {
  char last = buffer[length - 1];
  buffer[length - 1] = '\0';
  int result = inject(buffer, length);
  buffer[length - 1] = last;
  return result;
}

ssize_t (*original_write)(int fd, const void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count) {
  if (fd > 2) inject_safely((char *) buf, count);
  return original_write(fd, buf, count);
}

ssize_t (*original_send)(int sockfd, const void *buf, size_t len, int flags);
ssize_t send(int sockfd, const void *buf, size_t len, int flags) {
    inject_safely((char *) buf, len);
    return original_send(sockfd, buf, len, flags);
}

int (*original_SSL_write)(void *ssl, const void *buf, int num);
int SSL_write(void *ssl, const void *buf, int num) {
    inject_safely((char *) buf, (size_t) num);
    return original_SSL_write(ssl, buf, num);
}

ssize_t (*original_gnutls_record_send)(void *session, const void *data, size_t data_size);
ssize_t gnutls_record_send(void* session, const void* data, size_t data_size) {
  inject_safely((char*) data, data_size);
  return original_gnutls_record_send(session, data, data_size);
}

ssize_t (*original_gnutls_record_send2)(void *session, const void *data, size_t data_size, size_t pad, unsigned flags);
ssize_t gnutls_record_send2(void* session, const void* data, size_t data_size, size_t pad, unsigned flags) {
  inject_safely((char*) data, data_size);
  return original_gnutls_record_send2(session, data, data_size, pad, flags);
}

ssize_t (*original_gnutls_record_send_range)(void *session, const void *data, size_t data_size, const void *range);
ssize_t gnutls_record_send_range(void* session, const void* data, size_t data_size, const void *range) {
  inject_safely((char*) data, data_size);
  return original_gnutls_record_send_range(session, data, data_size, range);
}

int (*original_nghttp2_submit_request)(void *session, void *pri_spec, void *nva, size_t nvlen, void *data_prd, void *stream_user_data);
int nghttp2_submit_request(void *session, void *pri_spec, void *nva, size_t nvlen, void *data_prd, void *stream_user_data) {
  for (size_t index = 0; index < nvlen; index++) {
    void* nv = nva + (sizeof(void*) * 2 + sizeof(size_t) * 2 + 8) * index; // we are guessing struct layouts here, hella scary!
    char* key = * (char**) nv; nv += sizeof(char*);
    char* value = * (char**) nv; nv += sizeof(char*);
    size_t keylen = * (size_t*) nv; nv += sizeof(size_t);
    size_t valuelen = * (size_t*) nv; nv += sizeof(size_t);
    char* my_key = (char*) calloc(keylen + 1, sizeof(char));
    char* my_value = (char*) calloc(valuelen + 1, sizeof(char));
    memcpy(my_key, key, keylen);
    memcpy(my_value, value, valuelen);
    my_key[keylen] = '\0';
    my_value[valuelen] = '\0';
    if (strcmp(my_key, "traceparent") == 0) {
      FILE *sdk = fopen(getenv("OTEL_SHELL_INJECT_HTTP_SDK_PIPE"), "a+");
      if (!sdk) break;
      int span_handle = otel_span_start(sdk, "CLIENT", "HTTP");
      if (span_handle < 0) break;
      for (int i = 0; i < 1000 && access(getenv("OTEL_SHELL_INJECT_HTTP_HANDLE_FILE"), F_OK) == 0; i++) usleep(10 * 1000);
      {
        char span_handle_string[16];
        memset(span_handle_string, 0, 16);
        sprintf(span_handle_string, "%d", span_handle);
        FILE *storage = fopen(getenv("OTEL_SHELL_INJECT_HTTP_HANDLE_FILE"), "w");
        if (!storage) break;
        fwrite(span_handle_string, sizeof(char), strlen(span_handle_string), storage);
        fclose(storage);
      }
      char *traceparent = otel_traceparent(sdk, span_handle);
      if (!traceparent) break;
      if (strlen(traceparent) != valuelen) { free(traceparent); break; }
      memcpy(key, traceparent, valuelen);
      free(traceparent);
      fclose(sdk);
    }
    free(my_key);
    free(my_value);
  }
  return original_nghttp2_submit_request(session, pri_spec, nva, nvlen, data_prd, stream_user_data);
}

__attribute__ ((constructor))
void init() {
    original_write = dlsym(RTLD_NEXT, "write");
    original_send = dlsym(RTLD_NEXT, "send");
    original_SSL_write = dlsym(RTLD_NEXT, "SSL_write");
    original_gnutls_record_send = dlsym(RTLD_NEXT, "gnutls_record_send");
    original_gnutls_record_send2 = dlsym(RTLD_NEXT, "gnutls_record_send2");
    original_gnutls_record_send_range = dlsym(RTLD_NEXT, "gnutls_record_send_range");
    original_nghttp2_submit_request = dlsym(RTLD_NEXT, "nghttp2_submit_request");
}
