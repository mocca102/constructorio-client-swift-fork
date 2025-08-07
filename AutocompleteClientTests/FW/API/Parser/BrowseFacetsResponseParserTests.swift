//
//  BrowseFacetsResponseParserTests.swift
//  AutocompleteClientTests
//
//  Copyright (c) Constructor.io Corporation. All rights reserved.
//  http://constructor.io/
//

@testable import ConstructorAutocomplete
import XCTest

class BrowseFacetsResponseParserTests: XCTestCase {

    var parser: BrowseFacetsResponseParser!

    override func setUp() {
        super.setUp()
        self.parser = BrowseFacetsResponseParser()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBrowseFacetsParser_ParsingJSONString_ParsesStatusPropertyCorrectly() {
        let data = TestResource.load(name: TestResource.Response.browseFacetsJSONFilename)
        do {
            let response = try self.parser.parse(browseFacetsResponseData: data)
            
            // Test that we have the expected number of facets
            XCTAssertEqual(response.facets.count, 7, "Should parse all 7 facets from the JSON")
            
            // Find the facet with empty status object
            let emptyStatusFacet = response.facets.first { $0.name == "price" }
            XCTAssertNotNil(emptyStatusFacet, "Should find the 'price' facet")
            XCTAssertNotNil(emptyStatusFacet?.status, "Status should not be nil for 'price' facet")
            XCTAssertTrue(emptyStatusFacet?.status?.isEmpty == true, "Status should be an empty dictionary for 'price' facet")
            
            // Test min/max values are preserved as Double
            XCTAssertEqual(emptyStatusFacet?.min, 3.99, "Min value should be preserved as 3.99")
            XCTAssertEqual(emptyStatusFacet?.max, 950.0, "Max value should be preserved as 950.0")
            
            // Find the facet with populated status object
            let populatedStatusFacet = response.facets.first { $0.name == "price_selected" }
            XCTAssertNotNil(populatedStatusFacet, "Should find the 'price_selected' facet")
            XCTAssertNotNil(populatedStatusFacet?.status, "Status should not be nil for 'price_selected' facet")
            XCTAssertFalse(populatedStatusFacet?.status?.isEmpty == true, "Status should not be empty for 'price_selected' facet")
            
            // Test status dictionary contains expected values
            let statusDict = populatedStatusFacet?.status
            XCTAssertEqual(statusDict?["min"] as? String, "-inf", "Status min should be '-inf'")
            XCTAssertEqual(statusDict?["max"] as? Double, 100.25, "Status max should be 100.25")
            
            // Test min/max values are preserved as Double
            XCTAssertEqual(populatedStatusFacet?.min, 41.99, "Min value should be preserved as 41.99")
            XCTAssertEqual(populatedStatusFacet?.max, 400.0, "Max value should be preserved as 400.0")
            
            // Test facets without status property
            let noStatusFacet = response.facets.first { $0.name == "brand" }
            XCTAssertNotNil(noStatusFacet, "Should find the 'brand' facet")
            XCTAssertNil(noStatusFacet?.status, "Status should be nil for facets without status property")
            XCTAssertNil(noStatusFacet?.min, "Min should be nil for facets without min property")
            XCTAssertNil(noStatusFacet?.max, "Max should be nil for facets without max property")
            
        } catch {
            XCTFail("Parser should never throw an exception when a valid JSON string is passed.")
        }
    }
    
    func testBrowseFacetsParser_ParsingJSONString_HandlesVariousStatusTypes() {
        let data = TestResource.load(name: TestResource.Response.browseFacetsJSONFilename)
        do {
            let response = try self.parser.parse(browseFacetsResponseData: data)
            
            // Test that status property can handle different value types
            let populatedStatusFacet = response.facets.first { $0.name == "price_selected" }
            guard let statusDict = populatedStatusFacet?.status else {
                XCTFail("Status dictionary should not be nil")
                return
            }
            
            // Verify that status preserves original types
            XCTAssertTrue(statusDict["min"] is String, "Status min should preserve String type")
            XCTAssertTrue(statusDict["max"] is Double, "Status max should preserve Double type")
            
            // Verify the actual values
            XCTAssertEqual(statusDict["min"] as? String, "-inf")
            XCTAssertEqual(statusDict["max"] as? Double, 100.25)
            
        } catch {
            XCTFail("Parser should never throw an exception when a valid JSON string is passed.")
        }
    }
}
