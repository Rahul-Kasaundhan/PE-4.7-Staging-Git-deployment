public class CommonLayoutWrapper {

	public List<EditLayoutSections> editLayoutSections;

	public class Details {
		public String name;
		public List<PicklistValues> picklistValues;
	}

	public class PicklistValues {
		public Boolean active;
		public String label;
		public String value;
	}

	public class EditLayoutSections {
		public List<LayoutRows> layoutRows;
	}

	public class LayoutItems {
		public Boolean editableForNew;
		public Boolean editableForUpdate;
		public List<LayoutComponents> layoutComponents;
		public Boolean required;
	}

	public class LayoutComponents {
		public Details details;
		public String value;
	}

	public class LayoutRows {
		public List<LayoutItems> layoutItems;
	}

	
	public static CommonLayoutWrapper parse(String json) {
		return (CommonLayoutWrapper) System.JSON.deserialize(json, CommonLayoutWrapper.class);
	}
}