setup2
GT.M 04-JUN-2012 16:35:53
^LTree("tree1",1,"child",1,"child",1,"addTo")
CentrePanel
^LTree("tree1",1,"child",1,"child",1,"nextPage")
Chart2
^LTree("tree1",1,"child",1,"child",1,"replacePreviousPage")
true
^LTree("tree1",1,"child",1,"child",1,"text")
Patients by Age
^LTree("tree1",1,"child",1,"child",2,"addTo")
CentrePanel
^LTree("tree1",1,"child",1,"child",2,"iconCls")
user
^LTree("tree1",1,"child",1,"child",2,"nextPage")
Chart
^LTree("tree1",1,"child",1,"child",2,"replacePreviousPage")
true
^LTree("tree1",1,"child",1,"child",2,"text")
Patients by Dept
^LTree("tree1",1,"child",1,"text")
Patient Charts
^LTree("tree1",1,"child",2,"child",1,"addTo")
CentrePanel
^LTree("tree1",1,"child",2,"child",1,"nextPage")
PatGrid
^LTree("tree1",1,"child",2,"child",1,"replacePreviousPage")
true
^LTree("tree1",1,"child",2,"child",1,"text")
All patients
^LTree("tree1",1,"child",2,"text")
Patient Grids
^LTree("tree1",1,"expanded")
true
^LTree("tree1",1,"text")
charts and Grids
^LTree("tree1",2,"child",1,"addTo")
SouthPanel
^LTree("tree1",2,"child",1,"nextPage")
ChangeMode
^LTree("tree1",2,"child",1,"nvp")
EdDispWin=editMWin
^LTree("tree1",2,"child",1,"text")
Show popups
^LTree("tree1",2,"child",2,"addTo")
SouthPanel
^LTree("tree1",2,"child",2,"nextPage")
ChangeMode
^LTree("tree1",2,"child",2,"nvp")
EdDispWin=EastPanel
^LTree("tree1",2,"child",2,"text")
Show in panel
^LTree("tree1",2,"expanded")
false
^LTree("tree1",2,"text")
Maintenance
^LTree("tree2",1,"child",1,"nvp")
Episode
^LTree("tree2",1,"child",1,"text")
Episodes
^LTree("tree2",1,"child",2,"nvp")
Clinical note
^LTree("tree2",1,"child",2,"text")
Notes
^LTree("tree2",1,"child",3,"nvp")
Vitals
^LTree("tree2",1,"child",3,"text")
Vitals
^LTree("tree2",1,"child",4,"nvp")
Orders
^LTree("tree2",1,"child",4,"text")
Orders
^LTree("tree2",1,"child",5,"nvp")
Results
^LTree("tree2",1,"child",5,"text")
Results
^LTree("tree2",1,"child",6,"nvp")
Treatments
^LTree("tree2",1,"child",6,"text")
Treatments
^LTree("tree2",1,"child",7,"nvp")
Medications
^LTree("tree2",1,"child",7,"text")
Medications
^LTree("tree2",1,"text")
Filters
^LTree("tree3",1,"child",1,"child",1,"nvp")
item.get('age') <16
^LTree("tree3",1,"child",1,"child",1,"text")
Patients < 16
^LTree("tree3",1,"child",1,"child",2,"nvp")
item.get('age') >80
^LTree("tree3",1,"child",1,"child",2,"text")
Patients > 80
^LTree("tree3",1,"child",1,"text")
Patients by Age
^LTree("tree3",1,"child",2,"child",1,"nvp")
item.get('sex') =='M'
^LTree("tree3",1,"child",2,"child",1,"text")
Patients - Male
^LTree("tree3",1,"child",2,"child",2,"nvp")
item.get('sex') =='F'
^LTree("tree3",1,"child",2,"child",2,"text")
Patients - female
^LTree("tree3",1,"child",2,"text")
Patients by Sex
^LTree("tree3",1,"child",3,"child",1,"nvp")
item.get('dept') =='Emergency'
^LTree("tree3",1,"child",3,"child",1,"text")
Emergency
^LTree("tree3",1,"child",3,"child",2,"nvp")
item.get('dept') =='Inpatient'
^LTree("tree3",1,"child",3,"child",2,"text")
Inpatient
^LTree("tree3",1,"child",3,"child",3,"nvp")
item.get('dept') =='Outpatient'
^LTree("tree3",1,"child",3,"child",3,"text")
Outpatient
^LTree("tree3",1,"child",3,"text")
Patients by Dept
^LTree("tree3",1,"text")
Filters


