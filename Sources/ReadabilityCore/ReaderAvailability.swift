/// An enumeration representing the availability status of the reader mode.
public enum ReaderAvailability: String, Sendable {
    /// The reader mode is available.
    case available = "Available"
    /// The reader mode is unavailable.
    case unavailable = "Unavailable"
}
