if ! which java; then exit 0; fi
. ./assert.sh

[ "$(java --version | head -n 1 | cut -d ' ' -f 2 | cut -d . -f 1)" -ge 8 ] || exit 0

export OTEL_SHELL_CONFIG_INJECT_DEEP=TRUE
. otel.sh

dir=$(mktemp -d)
echo '
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class Main {
    public static void main(String[] args) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) new URL("http://example.com").openConnection();
        connection.setRequestMethod("GET");
        try (BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
            for (String line = in.readLine(); line != null; line = in.readLine());
        }
        connection.disconnect();
    }
}
' > "$dir"/Main.java
javac "$dir"/Main.java
(cd "$dir" && java Main)

dir=$(mktemp -d)
echo '
public class Main {
    public static void main(String[] args) throws InterruptedException, java.io.IOException {
        new ProcessBuilder("echo", "hello", "world", "0").redirectOutput(ProcessBuilder.Redirect.INHERIT).redirectError(ProcessBuilder.Redirect.INHERIT).start().waitFor();
        new ProcessBuilder("echo", "hello world", "1").redirectOutput(ProcessBuilder.Redirect.INHERIT).redirectError(ProcessBuilder.Redirect.INHERIT).start().waitFor();
        Runtime.getRuntime().exec(new String[]{"echo", "hello", "world", "2"}).waitFor();
        Runtime.getRuntime().exec(new String[]{"echo", "hello", "world", "3"}, null, null).waitFor();
    }
}
' > "$dir"/Main.java
javac "$dir"/Main.java
(cd "$dir" && java Main)
span="$(resolve_span '.name == "echo hello world 0"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')
span="$(resolve_span '.name == "echo hello world 1"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')
span="$(resolve_span '.name == "echo hello world 2"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')
span="$(resolve_span '.name == "echo hello world 3"')"
assert_equals "SpanKind.INTERNAL" $(\echo "$span" | jq -r '.kind')
assert_not_equals null $(\echo "$span" | jq -r '.parent_id')
