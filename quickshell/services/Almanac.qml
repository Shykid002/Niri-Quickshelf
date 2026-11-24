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

    // One line per day, picked by day of year.
    // Index 8 is the Frost line, so day 320 (16 Nov) matches the reference frames.
    readonly property var verses: [
        // Original Public-Domain Poets
        { text: "Hope is the thing with feathers",                     by: "Emily Dickinson" },
        { text: "A thing of beauty is a joy for ever",                 by: "John Keats" },
        { text: "If Winter comes, can Spring be far behind?",          by: "Percy Bysshe Shelley" },
        { text: "To see a World in a Grain of Sand",                   by: "William Blake" },
        { text: "I wandered lonely as a cloud",                        by: "William Wordsworth" },
        { text: "The world is too much with us",                       by: "William Wordsworth" },
        { text: "I celebrate myself, and sing myself",                 by: "Walt Whitman" },
        { text: "Season of mists and mellow fruitfulness",             by: "John Keats" },
        { text: "The woods are lovely, dark and deep",                 by: "Robert Frost" },
        { text: "Because I could not stop for Death",                  by: "Emily Dickinson" },
        { text: "Two roads diverged in a yellow wood",                 by: "Robert Frost" },
        { text: "Tyger Tyger, burning bright",                         by: "William Blake" },

        // Chinese Philosophy & Strategy
        { text: "To confuse your enemy, you must first confuse yourself", by: "Sun Tzu" },
        { text: "All warfare is based on deception",                   by: "Sun Tzu" },
        { text: "Appear weak when you are strong, strong when weak",   by: "Sun Tzu" },
        { text: "In the midst of chaos, there is also opportunity",    by: "Sun Tzu" },
        { text: "A journey of a thousand miles begins with one step",  by: "Laozi" },
        { text: "He who knows does not speak; he who speaks knows not",by: "Laozi" },
        { text: "Nature does not hurry, yet everything is accomplished",by: "Laozi" },
        { text: "When I let go of what I am, I become what I might be",by: "Laozi" },
        { text: "It does not matter how slowly you go so long as you do not stop", by: "Confucius" },
        { text: "Real knowledge is to know the extent of one's ignorance", by: "Confucius" },
        { text: "Happiness is the absence of the striving for happiness",  by: "Zhuangzi" },
        { text: "The best time to plant a tree was twenty years ago",  by: "Chinese Proverb" },
        { text: "Dig the well before you are thirsty",                 by: "Chinese Proverb" },
        { text: "A gem cannot be polished without friction",           by: "Chinese Proverb" },

        // Japanese Strategy, Zen & Literature
        { text: "You must understand that there is more than one path to the top of the mountain", by: "Miyamoto Musashi" },
        { text: "Do nothing that is of no use",                        by: "Miyamoto Musashi" },
        { text: "Today is victory over yourself of yesterday",         by: "Miyamoto Musashi" },
        { text: "Perceive that which cannot be seen with the eye",     by: "Miyamoto Musashi" },
        { text: "Every day is a journey, and the journey itself home", by: "Matsuo Bashō" },
        { text: "Do not seek to follow in the footsteps of the wise; seek what they sought", by: "Matsuo Bashō" },
        { text: "The most precious thing in life is its uncertainty",  by: "Yoshida Kenkō" },
        { text: "Fall seven times, stand up eight",                    by: "Japanese Proverb" },
        { text: "Even monkeys fall from trees",                        by: "Japanese Proverb" },
        { text: "The nail that sticks out gets hammered down",         by: "Japanese Proverb" },
        { text: "Vision without action is a daydream",                 by: "Japanese Proverb" },
        { text: "Silence is golden, eloquence is silver",              by: "Japanese Proverb" }
    ]

    property int verseOffset: 0
    readonly property var verse: verses[(dayOfYear + verseOffset) % verses.length]
    function nextVerse() { verseOffset = (verseOffset + 1) % verses.length }
    function randomVerse() {
        if (verses.length <= 1) return;
        const cur = (dayOfYear + verseOffset) % verses.length;
        let pick = cur;
        while (pick === cur) pick = Math.floor(Math.random() * verses.length);
        verseOffset = (pick - (dayOfYear % verses.length) + verses.length) % verses.length;
    }
}

