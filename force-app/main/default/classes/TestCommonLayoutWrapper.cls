@IsTest
public class TestCommonLayoutWrapper {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"editLayoutSections\": ['+
		'    {'+
		'      \"layoutRows\": ['+
		'        {'+
		'          \"layoutItems\": ['+
		'            {'+
		'              \"editableForNew\": true,'+
		'              \"editableForUpdate\": true,'+
		'              \"layoutComponents\": ['+
		'                {'+
		'                  \"details\": {'+
		'                    \"name\": \"Name\",'+
		'                    \"picklistValues\": ['+
		'                      {'+
		'                        \"active\": true,'+
		'                        \"label\": \"1\",'+
		'                        \"value\": \"1\"'+
		'                      }'+
		'                    ]'+
		'                  },'+
		'                  \"value\": \"Name\"'+
		'                }'+
		'              ],'+
		'              \"required\": true'+
		'            }'+
		'          ]'+
		'        }'+
		'      ]'+
		'    }'+
		'  ]'+
		'}';
		CommonLayoutWrapper obj = CommonLayoutWrapper.parse(json);
		System.assert(obj != null);
	}
}