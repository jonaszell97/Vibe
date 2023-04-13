
import Cryo
import Foundation

public struct Vibe<Value: Codable> {
    /// The ID of this vibe.
    public let id: UUID
    
    /// The ID of the vibe option.
    public let option: VibeOption<Value>
}

struct VibeModel: CryoModel {
    /// The ID of the vibe.
    @CryoColumn var id: String
    
    /// The vibe option.
    @CryoOneToOne var option: VibeOptionModel
}
