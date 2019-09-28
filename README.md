# ExDiff

**Get a simple diff of two nested mixed structures**

## Diff

diff is modeled as
```
@type t :: %{
          (String.t()
           | atom()) => diff()
        }

@type diff :: %{
      removed: [String.t() | atom()],
      added: [String.t() | atom()],
      changed: %{
        (String.t()
         | atom()) => %{
          old_value: String.t(),
          new_value: String.t()
        }
      }
    }
```

## Usage

Here are some usage examples

diff between one level maps
```
ExDiff.diff(
          %{
            key_in_both: "old_value",
            removed_key: "only_in_map_1"
          },
          %{
            key_in_both: "new_value",
            added_key: "only_in_map_2"
          }
        )
```

diff will be
```
%{
    "root" => %{
         added: [:added_key],
         changed: %{
           key_in_both: %{
             new_value: "\"new_value\"",
             old_value: "\"old_value\""
           }
         },
         removed: [:removed_key]
    }
}
```
---
diff between nested maps
```
ExDiff.diff(
          %{
            nested_map: %{
              key_in_both: "old_value",
              removed_key: "only_in_map_1"
            }
          },
          %{
            nested_map: %{
              key_in_both: "new_value",
              added_key: "only_in_map_2"
            }
          }
        )
```
diff will be
```
%{
   "root" => %{
     nested_map: %{
       added: [:added_key],
       changed: %{
         key_in_both: %{
           new_value: "\"new_value\"",
           old_value: "\"old_value\""
         }
       },
       removed: [:removed_key]
     }
   }
 }
```
