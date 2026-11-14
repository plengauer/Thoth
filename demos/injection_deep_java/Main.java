import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

// The demo is compiled and started by its plain file name
@SuppressWarnings("PMD.NoPackage")
public class Main {
    public static void main(String[] args) {
        try {
            HttpURLConnection connection = (HttpURLConnection) new URL("http://example.com").openConnection();
            connection.setRequestMethod("GET");
            try (BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                for (String line = in.readLine(); line != null; line = in.readLine());
            }
            connection.disconnect();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
