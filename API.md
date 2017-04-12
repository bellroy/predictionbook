# JSON API

GET http://predictionbook.com/api/predictions

Parameter name | Value   | Description
---------------| --------|------------
api_token      | string  | A token that identifies a unique user
limit          | integer | The maximum number of predictions that will be returned (optional)

GET http://predictionbook.com/api/predictions/:id

Parameter name | Value   | Description
---------------| --------|------------
api_token      | string  | A token that identifies a unique user
id             | integer | The prediction id

POST http://predictionbook.com/api/predictions

Parameter name                | Value   | Description
------------------------------| --------|------------
api_token                     | string  | A token that identifies a unique user
prediction[description]       | string  | Your prediction statement
prediction[deadline]          | date    | when it will/won't have happened
prediction[initial_confidence]| integer | A probability assignment
prediction[visibility]        | integer | 0 Public, 1 Private (optional, default public)

PUT http://predictionbook.com/api/predictions/:id

Parameter name                | Value   | Description
------------------------------| --------|------------
api_token                     | string  | A token that identifies a unique user
prediction[description]       | string  | Your prediction statement
prediction[deadline]          | date    | When it will/won't have happened
prediction[visibility]        | integer | 0 Public, 1 Private (optional, default public)
