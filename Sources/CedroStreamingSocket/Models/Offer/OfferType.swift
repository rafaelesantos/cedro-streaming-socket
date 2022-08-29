import Foundation

public enum OfferType: String, Codable {
    /// O tipo L indica oferta Limitada
    case limited = "L"
    /// O oferta ao preço de Abertura
    case openPrice = "O"
    /// X oferta ao melhor preço
    case bestPrice = "X"
    /// M oferta ao preço de Mercado.
    case marketPrice = "M"
}
