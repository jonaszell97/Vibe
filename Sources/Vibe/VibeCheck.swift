
import Cryo
import Foundation

public final class VibeCheck<Value: Codable> {
    /// The ID of the test.
    public let id: UUID
    
    /// The name of the test.
    public let name: String
    
    /// The start date of the test.
    public let startDate: Date
    
    /// The end date of the test.
    public let endDate: Date
    
    /// The different options of this test.
    public let options: [VibeOption<Value>]
    
    /// Create a vibe check.
    public init(id: UUID, name: String, startDate: Date, endDate: Date, options: [VibeOption<Value>]) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.options = options
    }
}

struct VibeCheckModel: CryoModel {
    /// The ID of the test.
    @CryoColumn var id: String
    
    /// The name of the test.
    @CryoColumn var name: String
    
    /// The start date of the test.
    @CryoColumn var startDate: Date
    
    /// The end date of the test.
    @CryoColumn var endDate: Date
}
