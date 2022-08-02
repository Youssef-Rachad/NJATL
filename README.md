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

- todolist create 'my todo @due+project+project'
    - todolist -action=create -content='my todo @due+project+project'
    - todolist -action=create -task='my todo' -duedate='due' -projects='project project'

- todolist mark idx status
    - todolist -action=mark -index=idx -status=status

- todolist list filters statuses
    - todolist -action=list -filter=filters -status=statuses

- todolist remove idx
    - todolist -action=remove -index=idx

- todolist edit idx 'my todo @due+project'
    - todolist -action=edit -index=idx -content='my todo @due+project'
    - (TODO) todolist -action=edit -index=idx -task='my todo' -duedate='due' -projects='project project'
