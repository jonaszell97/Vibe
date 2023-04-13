
import Cryo
import Foundation

public protocol AnyVibeOption {
    /// The value type.
    associatedtype Value: Codable

    /// The ID of this option.
    var id: UUID { get }
    
    /// The name of this option.
    var name: String { get }
    
    /// The weight of this option.
    var weight: Int { get }
    
    /// The value of this option.
    var value: Value { get }
}

public struct VibeOption<Value: Codable>: AnyVibeOption {
    /// The ID of this option.
    public let id: UUID
    
    /// The name of this option.
    public let name: String
    
    /// The weight of this option.
    public let weight: Int
    
    /// The value of this option.
    public let value: Value
}

struct VibeOptionModel: CryoModel {
    /// The ID of the option.
    @CryoColumn var id: String
    
    /// The vibe check this option belongs to.
    @CryoOneToOne var vibeCheck: VibeCheckModel
    
    /// The name of the option.
    @CryoColumn var name: String
    
    /// The weight of this option.
    @CryoColumn var weight: Int
    
    /// The value of this option.
    @CryoColumn var value: Data
}
