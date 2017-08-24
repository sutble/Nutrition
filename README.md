# Nutrition

This is my take on the "myfitnesspal" type calorie tracker app. Most of the free apps on the market lack Macro tracking (carbs, fat, protein), do not allow export of data outside the app, or have clunky and bloated UI. 

### Food Tableview

This tableview is populated from a list hosted on Firebase. It clearly presents the required info for each food (calories, carbs, protein, fat). In addition each element is color coded (red/green for high/low calories) and the other colors appear when the particular food item contains a large amount of the macro. This allows for users to understand the food item in a quick glance without additional screens. 

### Calorie Tracker Chart

This is a new UI element I designed to intuitively see how many remaining grams of specific macros you have for the day. The Pie Chart is broken into 3 sections (Protein, Carbs, Fat) and the striped region represents the empty portion. As the user enters food items into the chart, the specific macros fill up with solid color. If the user goes above the macros goal he has set for himself (including the calories listed in the center) that portion of the pie chart turns red. If he hits his goal (within a threshold) the chart turns green. 


![Alt text](https://user-images.githubusercontent.com/10662653/29652765-cfed9d46-885b-11e7-814a-0b2b6d9f40e0.gif  "Demo")
