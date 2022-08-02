//
//  CharityLicenseIdAndMoreFieldsMigration.swift
//  
//
//  Created by AmirHossein on 7/30/22.
//

import Vapor
import Fluent

struct CharityLicenseIdAndMoreFieldsMigration: Migration {
    private let schema = "Charity"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .field("images", .array(of: .string))
            .field("logoImage", .string)
            .field("countryId", .int)
            .field("provinceId", .int)
            .field("cityId", .int)
            .field("countryName", .string)
            .field("provinceName", .string)
            .field("cityName", .string)
            .field("whatsApp", .string)
            .field("managerName", .string)
            .field("licenseId", .string)
            .field("licenseDate", .date)
            .field("institutionIssuedLicense", .string)
            .field("licenseImages", .array(of: .string))
            .field("bankAccountNumber", .string)
            .field("bankName", .string)
            .field("bankAccountOwner", .string)
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteField("images")
            .deleteField("logoImage")
            .deleteField("countryId")
            .deleteField("provinceId")
            .deleteField("cityId")
            .deleteField("countryName")
            .deleteField("provinceName")
            .deleteField("cityName")
            .deleteField("whatsApp")
            .deleteField("managerName")
            .deleteField("licenseId")
            .deleteField("licenseDate")
            .deleteField("institutionIssuedLicense")
            .deleteField("licenseImages")
            .deleteField("bankAccountNumber")
            .deleteField("bankName")
            .deleteField("bankAccountOwner")
            .update()
    }
}
