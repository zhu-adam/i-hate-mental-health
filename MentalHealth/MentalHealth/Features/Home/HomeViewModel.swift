import Foundation

struct Quote {
    let text: String
    let author: String
}

let quotes: [Quote] = [
    Quote(text: "You don't have to control your thoughts. You just have to stop letting them control you.", author: "Dan Millman"),
    Quote(text: "There is hope, even when your brain tells you there isn't.", author: "John Green"),
    Quote(text: "Mental health is not a destination, but a process. It's about how you drive, not where you're going.", author: "Noam Shpancer"),
    Quote(text: "You are not your illness. You have an individual story to tell.", author: "Julian Seifter"),
    Quote(text: "It's okay to not be okay.", author: "Unknown"),
    Quote(text: "Self-care is not selfish. You cannot serve from an empty vessel.", author: "Eleanor Brown"),
    Quote(text: "Healing is not linear.", author: "Unknown"),
    Quote(text: "You are enough, just as you are.", author: "Unknown"),
    Quote(text: "Be gentle with yourself. You are a child of the universe.", author: "Max Ehrmann"),
    Quote(text: "One small crack does not mean that you are broken. It means that you were put to the test and you didn't fall apart.", author: "Linda Poindexter"),
    Quote(text: "Tough times never last, but tough people do.", author: "Robert H. Schuller"),
    Quote(text: "Not until we are lost do we begin to understand ourselves.", author: "Henry David Thoreau"),
    Quote(text: "The greatest glory in living lies not in never falling, but in rising every time we fall.", author: "Nelson Mandela"),
    Quote(text: "You don't have to be positive all the time. It's perfectly okay to feel sad, angry, annoyed, frustrated, scared, or anxious.", author: "Lori Deschene"),
    Quote(text: "What mental health needs is more sunlight, more candor, more unashamed conversation.", author: "Glenn Close"),
    Quote(text: "Sometimes the people around you won't understand your journey. They don't need to — it's not for them.", author: "Joubert Botha"),
    Quote(text: "Your illness is not your identity. Your chemistry is not your character.", author: "Unknown"),
    Quote(text: "Start where you are. Use what you have. Do what you can.", author: "Arthur Ashe"),
    Quote(text: "It is okay to ask for help. It is a sign of strength, not weakness.", author: "Unknown"),
    Quote(text: "Promise me you'll always remember: you're braver than you believe, stronger than you seem, and smarter than you think.", author: "A.A. Milne"),
    Quote(text: "Recovery is not one and done. It is a lifelong journey that takes place one day, one step at a time.", author: "Unknown"),
    Quote(text: "You are worthy of love and belonging.", author: "Brené Brown"),
    Quote(text: "The most beautiful people we have known are those who have known defeat, known suffering, known struggle, known loss.", author: "Elisabeth Kübler-Ross"),
    Quote(text: "Give yourself the same compassion you would give a good friend.", author: "Unknown"),
    Quote(text: "Sometimes you climb out of bed in the morning and you think — I'm not going to make it. But you laugh and brush your teeth anyway.", author: "Charles Bukowski"),
]

@Observable
final class HomeViewModel {
    var quote: Quote = quotes[0]

    init() {
        quote = quotes.randomElement() ?? quotes[0]
    }

    func refreshQuote() {
        let current = quote
        var next = quotes.randomElement() ?? quotes[0]
        while next.text == current.text && quotes.count > 1 {
            next = quotes.randomElement() ?? quotes[0]
        }
        quote = next
    }
}
