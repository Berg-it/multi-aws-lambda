# multi-aws-lambda

To avoid copying and pasting the same piece of code to create many lambda in the same project, you can follow this config where you will just add the necessary information of your lambda into **lambda-template.json** file.

```
"FUNCTION_NAME_MUST_UNIQUE": {
        "function_name": "Optional_Fct_Name",
        "filename": "LOCATION_OF_ZIPPED_LAMDA_FILE",
        "handler": "HANDLER_NAME",
        "role": "IAM_ROLE_FOR_YOUR_LAMBDA",
        "runtime": "RUNTIME_ENV",
        "memory_size": MEMORY_SIZE,
        "set_env": HAVE_YOU_ENV_VARIABLE_OR_NOT_1_OR_0, 
        "environment": {
            
        }
    }
```    
