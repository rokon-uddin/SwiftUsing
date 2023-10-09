import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct UsingMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self) else {
            throw CustomError.message("No variable declaration")
        }
        
        let bindingKeyword = variableDeclaration.bindingSpecifier.tokenKind
        
        let mutable = switch bindingKeyword {
        case .keyword(let keyword):
            switch keyword {
            case .let: false
            case .var: true
            default: throw CustomError.message("Unsupported binding keyword")
            }
        default: throw CustomError.message("Unsupported binding keyword")
        }
        
        guard let bindings = variableDeclaration.bindings.first else {
            throw CustomError.message("No binding")
        }
        
        guard let pattern = bindings.pattern.as(IdentifierPatternSyntax.self) else {
            throw CustomError.message("No pattern")
        }
        
        let name = pattern.identifier.text
        
        guard let typeAnnotation = bindings.typeAnnotation?.as(TypeAnnotationSyntax.self) else {
            throw CustomError.message("No pattern")
        }
        
        let type = typeAnnotation.type.description
        
        if mutable {
            return [
                """
                subscript <T>(dynamicMember keyPath: WritableKeyPath<\(raw: type), T>) -> T {
                    get { \(raw: name)[keyPath: keyPath] }
                    set { \(raw: name)[keyPath: keyPath] = newValue }
                }
                """
            ]
        } else {
            return [
                """
                subscript<T>(dynamicMember keyPath: KeyPath<\(raw: type), T>) -> T {
                    \(raw: name)[keyPath: keyPath]
                }
                """
            ]
        }
    }
    
    
}

@main
struct SwiftUsingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UsingMacro.self,
    ]
}


enum CustomError: Error, CustomStringConvertible {
    case message(String)
    
    var description: String {
        switch self {
        case .message(let text): return text
        }
    }
}
