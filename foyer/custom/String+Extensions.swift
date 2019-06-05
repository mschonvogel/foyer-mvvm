import Foundation

extension String
{
    var replacedHtmlEntities: String {
        var str = self

        let replace = [
            "&ndash;" : "-",
            "&rdquo;" : "\"",
            "&ldquo;" : "\"",
            "&quot;"  : "\"",
            "&#039;"  : "'",
            "&lt;"    : "<",
            "&gt;"    : ">",
            "&#x2F;"  : "/"
        ]

        for (key, value) in replace {
            str = str.replacingOccurrences(of: key, with: value, options: .literal, range: nil)
        }

        return str
    }
}
