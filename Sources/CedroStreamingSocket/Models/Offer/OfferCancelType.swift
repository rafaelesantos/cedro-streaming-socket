import Foundation

public enum OfferCancelType: Int {
    /// O tipo 1 indica que somente a oferta da posição indicada deve ser cancelada.
    case indicatedPosition = 1
    /// O tipo 2 indica que todas as ofertas melhores do que a oferta indicada pela posição, inclusive ela, devem ser canceladas.
    case allBetterThenBest = 2
    /// O tipo 3 indica que todas as ofertas, tanto de compra quanto de venda, devem ser canceladas. Neste tipo a mensagem não vem acompanhada de direção e posição.
    case allBuySell = 3
}
