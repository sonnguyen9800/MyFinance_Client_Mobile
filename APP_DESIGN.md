The app is Flutter based, and is built using the Flutter SDK.

The app is a expense tracker app. Used for multiple users (multiple accounts). Use case is for family (<= 10 people)

The backend of the app had been created in port 8080

Here all API
[GIN-debug] POST   /api/login                --> main.handleLogin (3 handlers)
[GIN-debug] POST   /api/signup               --> main.handleSignup (3 handlers)
[GIN-debug] POST   /api/expenses             --> main.handleCreateExpense (4 handlers)
[GIN-debug] GET    /api/expenses             --> main.handleGetExpenses (4 handlers)
[GIN-debug] GET    /api/expenses/:id         --> main.handleGetExpense (4 handlers)
[GIN-debug] PUT    /api/expenses/:id         --> main.handleUpdateExpense (4 handlers)
[GIN-debug] DELETE /api/expenses/:id         --> main.handleDeleteExpense (4 handlers)

Now create the app in flutter and connect it to the backend

I want: 5 Scenes:
- Login Scene
- Home Scene
- Expenses Scene
- Chart Scene
- Profile Scene
- Settings Scene
- About Scene

Users has below fields:
- id (created automatically from mongodb)
- name
- email
- password (hashed)

Expenses has below fields:
- id (created automatically from mongodb)
- user id (created automatically from mongodb, they link the user who pay the expense)
- name
- description (optinal)
- date
- payment method
- amount (number)
- Currency Code (default is VND)
- category

Login Feature: If users never loggin to the app, they will be redirected to the login scene. If they loggin successfully, they will be redirected to the home scene.

In homescene, there are two main panel: Overview panel and Expenses panel. The overview panel shows the total expense in last 30 days, the total expense in last 7 days, and the expenses panel panel shows the list of expenses. The list is scrollable. There is a button to add new expense. There is a button to view full list of expenses in another scene (Expenses Scene).

In expenses scene, there is a list of expenses. The list is scrollable. There is a button to add new expense. Users can delete an expense. Users can update an expense here. Only expense owner can read, delete or update the expense.

In chart scene, the chart will charts the expenses in last 30 days. The chart can be zoomed in and out. Users can also click on the chart to see the details of the expenses. Users can select the date range of the chart.

In chart scene, there are button to switch to fan chart. The fan chart shows the expenses in last 30 days in a fan chart categorized by "category" of the expenses. The fan chart can be zoomed in and out. Users can also click on the fan chart to see the details of the expenses. Users can select the date range of the fan chart.

In profile scene, users can see their profile. Users can update their profile. Users can change their password. Users can delete their account.

In settings scene, users can change their language. Users can change their theme. Users can change their font size. Users can change their currency. Users can change their currency code.

In about scene, users can see the about page.