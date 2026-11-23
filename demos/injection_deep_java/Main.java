import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

// The demo is compiled and started by its plain file name
// Main is the conventional name of the entry point
// Making every local variable final is noise without a safety benefit
@SuppressWarnings({"PMD.NoPackage", "PMD.LocalVariableCouldBeFinal", "PMD.ShortClassName"})
public final class Main {
    private Main() {
    }

    public static void main(String[] args) {
        try {
            HttpURLConnection connection = (HttpURLConnection) new URL("http://example.com").openConnection();
            connection.setRequestMethod("GET");
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                String line = reader.readLine();
                while (line != null) {
                    line = reader.readLine();
                }
            }
            connection.disconnect();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
