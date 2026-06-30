enum MarketplaceSampleData {
    static let requests = [
        RequestOffer(isRequest: true, category: "Gartenarbeit", personName: "Margrit Buri"),
        RequestOffer(isRequest: true, category: "Briefversand abpacken", personName: "Regula Peters"),
        RequestOffer(isRequest: true, category: "Einkaufshilfe", personName: "Margrit Buri")
    ]

    static let offers = [
        RequestOffer(isRequest: false, category: "Handwerkliche Arbeiten", personName: "Marco Tanner"),
        RequestOffer(isRequest: false, category: "Klavierunterricht", personName: "Margrit Burgi"),
        RequestOffer(isRequest: false, category: "Deutsch lernen (Sprachtandem)", personName: "Jakob Rieder")
    ]
}
