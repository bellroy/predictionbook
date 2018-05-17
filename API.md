# JSON API

## Public predictions

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
prediction[visibility]        | string  | visible_to_everyone (default), visible_to_creator

PUT http://predictionbook.com/api/predictions/:id

Parameter name                | Value   | Description
------------------------------| --------|------------
api_token                     | string  | A token that identifies a unique user
prediction[description]       | string  | Your prediction statement
prediction[deadline]          | date    | When it will/won't have happened
prediction[visibility]        | string  | visible_to_everyone (default), visible_to_creator

## Your predictions, including private predictions

GET http://predictionbook.com/api/my_predictions/

Parameter name | Value   | Description
---------------| --------|------------
api_token      | string  | A token that identifies a unique user
page_size      | integer | Predictions returned per page (default 100, max 1000)
page           | integer | Increment to page through more than page_size predictions (default 1)
