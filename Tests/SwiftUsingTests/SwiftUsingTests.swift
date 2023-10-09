import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftUsingMacros)
import SwiftUsingMacros

let testMacros: [String: Macro.Type] = [
    "Using": UsingMacro.self,
]
#endif

final class SwiftUsingTests: XCTestCase {
    func testMacro() throws {
        #if canImport(SwiftUsingMacros)
        assertMacroExpansion(
            """
            struct Outer {
                let flag: Bool
                
                @Using
                let inner: Inner
                
                @Using
                var transform: Transform
            }
            """,
            expandedSource: 
            """
            struct Outer {
                let flag: Bool
                
                let inner: Inner

                subscript <T>(dynamicMember keyPath: KeyPath<Inner, T>) -> T {
                    inner[keyPath: keyPath]
                }
                
                var transform: Transform

                subscript <T>(dynamicMember keyPath: WritableKeyPath<Transform, T>) -> T {
                    get {
                        transform[keyPath: keyPath]
                    }
                    set {
                        transform[keyPath: keyPath] = newValue
                    }
                }
            }
            """,
            macros: testMacros
        )
        
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
