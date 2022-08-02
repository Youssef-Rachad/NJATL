# NJATL - Not Just Another Todo List

## Productivity Tracker
- Include metadata for each todo
- Query todos by filter
- ?? Get reminders

## Main Objectives
- [x] CRUD complete
- [DEPRECATED] Implement priority
- [x] Support PARA
    - Workspace, Project, Archive
- [x] Support Agile like structure
- [x] Due dates
- [ ] Implement filter system
    - [x] Filter by project
    - [x] Filter by status
- [ ] Archive mechanism
- [x] Shorthand commands and long form

## Secondary Objectives
- [ ] Start and End date
- [ ] Calendar integration
- [ ] Interactive editing (can get a reference for the todo
        before making an edit)
- [ ] Test the app

## Usage
Note that the shorthand uses are strict in formatting

- njatl create 'my todo @due+project+project'
    - njatl -action=create -content='my todo @due+project+project'
    - (TODO) njatl -action=create -task='my todo' -duedate='due' -projects='project project'

- njatl mark idx status
    - njatl -action=mark -index=idx -status=status

- njatl list filters statuses
    - njatl -action=list -filter=filters -status=statuses

- njatl remove idx
    - njatl -action=remove -index=idx

- njatl edit idx 'my todo @due+project'
    - njatl -action=edit -index=idx -content='my todo @due+project'
    - (TODO) njatl -action=edit -index=idx -task='my todo' -duedate='due' -projects='project project'
