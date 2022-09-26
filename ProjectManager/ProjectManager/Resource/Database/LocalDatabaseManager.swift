//
//  LocalDatabaseManager.swift
//  ProjectManager
//
//  Created by 수꿍, 휴 on 2022/09/07.
//

import CoreData

final class LocalDatabaseManager {
    static let inMemory = LocalDatabaseManager(isInMemory: true)

    private var isInMemory: Bool

    init(isInMemory: Bool) {
        self.isInMemory = isInMemory
    }

    private lazy var persistentContainer: CoreDataContainer = {
        let container = CoreDataContainer(name: "ProjectManager", inMemory: isInMemory)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func create(data: ProjectUnit) throws {
        let context = persistentContainer.viewContext
        let project = Project(context: context)

        project.setValue(data.title, forKey: "title")
        project.setValue(data.body, forKey: "body")
        project.setValue(data.deadLine, forKey: "deadLine")
        project.setValue(data.section, forKey: "section")
        project.setValue(data.id, forKey: "id")

        try save(context)
    }

    func fetchSection(_ section: String) throws -> [ProjectUnit] {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<Project>(entityName: "Project")
        request.predicate = NSPredicate(format: "section = %@", section)

        let projects = try context.fetch(request)
        let result = projects.compactMap { data -> ProjectUnit? in
            guard let title = data.title,
                  let body = data.body,
                  let deadLine = data.deadLine,
                  let section = data.section,
                  let id = data.id else {
                return nil
            }

            return ProjectUnit(
                id: id,
                title: title,
                body: body,
                section: section,
                deadLine: deadLine
            )
        }

        return result
    }

    func update(data: ProjectUnit) throws {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<Project>(entityName: "Project")
        request.predicate = NSPredicate(format: "id = %@", data.id as CVarArg)

        guard let project = try context.fetch(request).first else {
            throw DatabaseError.invalidFetchRequest
        }

        project.body = data.body
        project.title = data.title
        project.deadLine = data.deadLine
        project.section = data.section

        try save(context)
    }

    func delete(id: UUID) throws {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<Project>(entityName: "Project")
        request.predicate = NSPredicate(format: "id = %@", id as CVarArg)

        guard let project = try context.fetch(request).first else {
            throw DatabaseError.invalidFetchRequest
        }

        context.delete(project)

        try save(context)
    }

    private func save(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else {
            return
        }

        do {
            try context.save()
        } catch {
            throw DatabaseError.failedContextSave(error: error)
        }
    }
}
