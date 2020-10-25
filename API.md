# JSON API

## Public predictions

GET http://predictionbook.com/api/predictions

Parameter name | Value   | Description
---------------| --------|------------
api_token      | string  | A token that identifies a unique user
limit          | integer | The maximum number of predictions that will be returned. Also specifies page size when the page_number parameter is present. If not specified, defaults to 100. When specified, will be set to the minimum of 1000 or the specified value (optional)
page_number    | integer | The one-based (1 is the first page) page number of predictions that will be returned. When specified, data is returned in chronological order. When unspecified, data is returned in reverse chronological order (optional)

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
