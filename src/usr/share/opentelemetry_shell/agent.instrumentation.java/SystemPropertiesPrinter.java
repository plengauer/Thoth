public final class SystemPropertiesPrinter {
    private SystemPropertiesPrinter() {
    }

    public static void main(String[] args) {
       System.getProperties().list(System.out);
    }
}
