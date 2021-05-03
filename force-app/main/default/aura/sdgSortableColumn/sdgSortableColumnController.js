/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
  doInit: function(component, event, helper) {},
  sort: function(component, event, helper) {
    var field = component.get("v.SDGField");

    if (field.isEncrypted) {
      var navToast = $A.get("e.force:showToast");
      navToast.setParams({
        title: "",
        message: "Cannot sort encypted field"
      });
      navToast.fire();
    } 
    //Change to remove sorting from grouped field 002CG ~Akash for Grouping
    else if(field.groupingQuery) {}
    //Change to remove sorting from related association field in Phase3 CR by Akash(28-11-2019).
    else if(field.ColumnName && field.ColumnName.toLowerCase().includes('related_associations__c')) {}
    else {
      //throw an event to parent:
     
      var compEvent = component.getEvent("SDGSortableColumnSort");
      component.set("v.isSorted", true);

      compEvent.setParams({
        SDGFieldID: component.get("v.SDGField").ID,
        SortOrder: component.get("v.SortOrder")
      });
      compEvent.fire();
    }
  },
  sortchanged: function(component, event, handler) {
    if (
      component.get("v.SDGField").ID === component.get("v.CurrentSortedColumn")
    ) {
      if (component.get("v.CurrentSortedOrder") === "A") {
        component.set("v.isSortedD", false);
        component.set("v.isSortedA", true);
      } else {
        component.set("v.isSortedA", false);
        component.set("v.isSortedD", true);
      }
      component.set("v.isSorted", true);
    } else {
      component.set("v.isSortedA", false);
      component.set("v.isSortedD", false);
    }
  }
});