import Vapor

class PersonelController {

    func create(_ req: Request) throws -> Future<Personel> {
        return try req.content.decode(Personel.self).flatMap { requestInput in
            return requestInput.create(on: req)
        }
    }

    func getList(_ req: Request) throws -> Future<[Personel]> {
        return Personel.query(on: req).all()
    }
}
