//
//  BlueBerrySmoothieApp.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/30/24.
//

import SwiftUI
import SwiftData

@main
struct Macro_Study_SwiftDataApp: App {
        
    // MARK: - SwfitData
    var modelContainer: ModelContainer = {
        // 1. Schema 생성
        let schema = Schema([Alert.self])
        
        // 2. Model 관리 규칙을 위한 ModelConfiguration 생성
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        // 3. ModelContainer 생성
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        // 전역적으로 사용한 영구 데이터이기 때문에, WindowGroup에 주입
        .modelContainer(modelContainer)
    }
}
