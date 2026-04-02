#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

// forward [ forward arg1 arg2 NULL ] => EXECUTABLE [ EXECUTABLE ARG1 ARG2 arg1 arg2 NULL ]

#ifndef EXECUTABLE
#error must define executable
#endif

#define STR(s) XSTR(s)
#define XSTR(s) #s

int main(int argc, char **argv) {
#ifdef ARG2
    const char *cmd0 = STR(ARG2);
#else
    const char *cmd0 = argv[0];
#endif
    size_t total_length = strlen(cmd0);
    for (int j = 1; j < argc; j++) total_length += strlen(argv[j]) + 1;
    char *original_command = (char*) malloc(total_length + 1);
    original_command[0] = '\0';
    strcat(original_command, cmd0);
    for (int j = 1; j < argc; j++) {
        strcat(original_command, " ");
        strcat(original_command, argv[j]);
    }
    setenv("OTEL_SHELL_COMMAND_OVERRIDE", original_command, 1);
    free(original_command);
    
    int new_argc = argc;
#ifdef ARG1
    new_argc++;
#endif
#ifdef ARG2
    new_argc++;
#endif
    
    char **new_argv = (char**) calloc((size_t) new_argc + 1, sizeof(char*));
    int i = 0;
    new_argv[i++] = STR(EXECUTABLE);
#ifdef ARG1
    new_argv[i++] = STR(ARG1);
#endif
#ifdef ARG2
    new_argv[i++] = STR(ARG2);
#endif
    for (int j = 1; j < argc; j++) {
        new_argv[i++] = argv[j];
    }
    new_argv[i++] = NULL;
    
    execv(STR(EXECUTABLE), new_argv);
    perror("execv failed");
    free(new_argv);
    return 1;
}
