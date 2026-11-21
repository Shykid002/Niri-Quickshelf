pragma Singleton
import QtQuick
import Quickshell

// Everything the daily "book cover" needs: date words, day of year, Roman year, verse.
Singleton {
    id: root

    SystemClock { id: clock; precision: SystemClock.Minutes }

    readonly property date now: clock.date
    readonly property int  year:  now.getFullYear()
    readonly property int  month: now.getMonth()          // 0-based
    readonly property int  day:   now.getDate()
    readonly property int  dayOfYear:
        Math.round((Date.UTC(year, month, day) - Date.UTC(year, 0, 0)) / 86400000)

    readonly property var weekdays: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    readonly property var months: ["January", "February", "March", "April", "May", "June", "July",
                                   "August", "September", "October", "November", "December"]
    readonly property var ordinals: ["", "first", "second", "third", "fourth", "fifth", "sixth", "seventh",
        "eighth", "ninth", "tenth", "eleventh", "twelfth", "thirteenth", "fourteenth", "fifteenth",
        "sixteenth", "seventeenth", "eighteenth", "nineteenth", "twentieth", "twenty-first",
        "twenty-second", "twenty-third", "twenty-fourth", "twenty-fifth", "twenty-sixth",
        "twenty-seventh", "twenty-eighth", "twenty-ninth", "thirtieth", "thirty-first"]

    readonly property string weekday:  weekdays[now.getDay()]
    readonly property string monthName: months[month]
    readonly property string dateWords: "The " + ordinals[day] + " of " + monthName   // "The sixteenth of November"
    readonly property string numeral:  String(day)                                     // "16"
    readonly property string roman:    toRoman(year)                                   // "MMXXVI"
    readonly property string shortDate: weekday.slice(0, 3) + " " + day + " " + monthName.slice(0, 3)  // "Mon 16 Nov"
    readonly property string timeText:  pad(now.getHours()) + ":" + pad(now.getMinutes())             // "11:37"
    function pad(n) { return n < 10 ? "0" + n : "" + n }
    readonly property string coverNo:  "No. " + dayOfYear                              // "No. 320"

    function toRoman(n) {
        const t = [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"], [100, "C"], [90, "XC"],
                   [50, "L"], [40, "XL"], [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]];
        let s = "";
        for (const [v, r] of t) while (n >= v) { s += r; n -= v; }
        return s;
    }

    // One line per day, picked by day of year. Public-domain poets only.
    // Index 8 is the Frost line, so day 320 (16 Nov) matches the reference frames.
    readonly property var verses: [
        { text: "Hope is the thing with feathers",         by: "Emily Dickinson" },
        { text: "A thing of beauty is a joy for ever",     by: "John Keats" },
        { text: "If Winter comes, can Spring be far behind?", by: "Percy Bysshe Shelley" },
        { text: "To see a World in a Grain of Sand",       by: "William Blake" },
        { text: "I wandered lonely as a cloud",            by: "William Wordsworth" },
        { text: "The world is too much with us",           by: "William Wordsworth" },
        { text: "I celebrate myself, and sing myself",     by: "Walt Whitman" },
        { text: "Season of mists and mellow fruitfulness", by: "John Keats" },
        { text: "The woods are lovely, dark and deep",     by: "Robert Frost" },
        { text: "Because I could not stop for Death",      by: "Emily Dickinson" },
        { text: "Two roads diverged in a yellow wood",     by: "Robert Frost" },
        { text: "Tyger Tyger, burning bright",             by: "William Blake" }
    ]
    readonly property var verse: verses[dayOfYear % verses.length]
}
