
import Cryo
import Foundation

public struct VibeMetric {
    /// The ID of this metric.
    public let id: UUID
    
    /// The name of this metric.
    public let name: String
    
    /// The value of this metric.
    public let value: Decimal
}

struct VibeMetricModel: CryoModel {
    /// The ID of the metric.
    @CryoColumn var id: String
    
    /// The related vibe check.
    @CryoOneToOne var vibeCheck: VibeCheckModel
    
    /// The related option.
    @CryoOneToOne var option: VibeOptionModel
    
    /// The name of the metric.
    @CryoColumn var name: String
    
    /// The value of the metric.
    @CryoColumn var value: Decimal
}
