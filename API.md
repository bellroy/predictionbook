# JSON API

GET  http://predictionbook.com/api/predictions

Parameter name | Value   | Description
---------------| --------|------------
api_token      | string  | A token that identifies a unique user
limit          | integer | The maximum number of predictions that will be returned (optional)

POST  http://predictionbook.com/api/predictions

Parameter name                | Value   | Description
------------------------------| --------|----
api_token                     | string  | A token that identifies a unique user
prediction[description]       | string  | Your prediction statement
prediction[deadline]          | date    | when it will/won't have happened
prediction[initial_confidence]| integer | a probability assignment
prediction[private]           | boolean | true if you want it to be private (optional)