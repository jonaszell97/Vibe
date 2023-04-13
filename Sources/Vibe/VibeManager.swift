
import Cryo
import Foundation

public final class VibeManager: ObservableObject {
    /// The public CloudKit database.
    let publicDatabase: CloudKitAdaptor
    
    /// The private CloudKit database.
    let privateDatabase: CloudKitAdaptor
    
    /// The active vibes.
    var vibes: [any AnyVibeOption] = []
    
    /// Create a vibe manager.
    public init(publicDatabase: CloudKitAdaptor, privateDatabase: CloudKitAdaptor) {
        self.publicDatabase = publicDatabase
        self.privateDatabase = privateDatabase
    }
}

extension VibeManager {
    /// Create a new vibe check.
    public func createVibeCheck<Value: Codable>(_ check: VibeCheck<Value>) async throws {
        let model = VibeCheckModel(id: check.id.uuidString,
                                   name: check.name,
                                   startDate: check.startDate,
                                   endDate: check.endDate)
        
        try await publicDatabase.insert(model).execute()
        
        for option in check.options {
            let model = VibeOptionModel(id: option.id.uuidString,
                                        vibeCheck: model,
                                        name: option.name,
                                        weight: option.weight,
                                        value: try JSONEncoder().encode(option.value))
            
            try await publicDatabase.insert(model).execute()
        }
    }
}

extension VibeManager {
    /// Load an active vibe check with the given name.
    public func loadVibeCheck<Value: Codable>(_ name: String, as: Value.Type) async throws -> VibeCheck<Value>? {
        // Load the vibe check
        let now = Date.now
        let model = try await publicDatabase.select(from: VibeCheckModel.self)
            .where("name", equals: name)
            .where("startDate", isLessThanOrEquals: now)
            .where("endDate", isGreatherThanOrEquals: now)
            .execute().first
        
        guard let model else {
            return nil
        }
        
        let options =  try await publicDatabase.select(from: VibeOptionModel.self)
            .where("vibeCheck", equals: model.id)
            .execute()
            .map {
                VibeOption(id: .init(uuidString: $0.id)!,
                           name: $0.name,
                           weight: $0.weight,
                           value: try JSONDecoder().decode(Value.self, from: $0.value))
            }
        
        
        return VibeCheck(id: .init(uuidString: model.id)!,
                         name: model.name,
                         startDate: model.startDate,
                         endDate: model.endDate,
                         options: options)
    }
    
    /// Check if a vibe check with the given name already exists.
    public func activeVibeCheckExists<Value: Codable>(name: String, as: Value.Type) async throws -> Bool {
        let now = Date.now
        return try await publicDatabase.select(from: VibeCheckModel.self)
            .where("name", equals: name)
            .where("startDate", isLessThanOrEquals: now)
            .where("endDate", isGreatherThanOrEquals: now)
            .execute().count > 0
    }
    
    /// Retrieve the selected option for a VibeCheck.
    func getVibeOption<Value: Codable>(_ name: String, as: Value.Type) async throws -> VibeOptionModel? {
        // Load the vibe check
        let now = Date.now
        let vibeCheck = try await publicDatabase.select(from: VibeCheckModel.self)
            .where("name", equals: name)
            .where("startDate", isLessThanOrEquals: now)
            .where("endDate", isGreatherThanOrEquals: now)
            .execute().first
        
        guard let vibeCheck else {
            return nil
        }
        
        // Check if an option exists for this vibe
        let vibeOption = try await privateDatabase.select(from: VibeModel.self)
            .where("vibeCheck", equals: vibeCheck.id)
            .execute().first
        
        if let vibeOption {
            return vibeOption.option
        }
        
        // Select a Vibe
        let availableOptions = try await publicDatabase.select(from: VibeOptionModel.self)
            .where("vibeCheck", equals: vibeCheck.id)
            .execute()
        
        guard !availableOptions.isEmpty else {
            return nil
        }
        
        var sum = 0
        var selectedOption: VibeOptionModel? = nil
        let totalWeight = availableOptions.reduce(0) { $0 + $1.weight }
        let randomNumber = Int.random(in: 0..<totalWeight)
        
        for option in availableOptions {
            sum += option.weight
            
            if randomNumber < sum {
                selectedOption = option
                break
            }
        }
        
        guard let selectedOption else {
            return nil
        }
        
        // Save the result
        let optionModel = VibeModel(id: UUID().uuidString, option: selectedOption)
        try await privateDatabase.insert(optionModel).execute()
        
        return selectedOption
    }
    
    /// Retrieve the selected option for a VibeCheck.
    public func feelVibe<Value: Codable>(_ name: String, as: Value.Type) async throws -> Value? {
        guard let selectedOption = try await self.getVibeOption(name, as: Value.self) else {
            return nil
        }
        
        return try JSONDecoder().decode(Value.self, from: selectedOption.value)
    }
}

extension VibeManager {
    /// Submit a metric for the given vibe.
    public func submitMetric<Value: Codable>(_ name: String, value: Decimal, vibeName: String, vibeValue: Value.Type) async throws {
        guard let selectedOption = try await self.getVibeOption(vibeName, as: Value.self) else {
            return
        }
        
        let model = VibeMetricModel(id: UUID().uuidString, vibeCheck: selectedOption.vibeCheck,
                                    option: selectedOption, name: name, value: value)
        
        try await publicDatabase.insert(model).execute()
    }
    
    /// Load the metrics for a given vibe check.
    public func loadMetrics<Value: Codable>(vibeName: String, vibeValue: Value.Type) async throws -> [UUID: VibeMetric]? {
        let now = Date.now
        let vibeCheck = try await publicDatabase.select(from: VibeCheckModel.self)
            .where("name", equals: vibeName)
            .where("startDate", isLessThanOrEquals: now)
            .where("endDate", isGreatherThanOrEquals: now)
            .execute().first
        
        guard let vibeCheck else {
            return nil
        }
        
        let metrics = try await publicDatabase.select(from: VibeMetricModel.self)
            .where("vibeCheck", equals: vibeCheck.id)
            .execute()
        
        var result = [UUID: VibeMetric]()
        for metric in metrics {
            result[.init(uuidString: metric.option.id)!] = .init(id: .init(uuidString: metric.id)!,
                                                                 name: metric.name,
                                                                 value: metric.value)
        }
        
        return result
    }
}
