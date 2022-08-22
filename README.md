# NJATL - Not Just Another Todo List

_Show me the information I need_

## Productivity Tracker
- Include metadata for each todo
- Query todos by filter
- Get reminders

## Requirements
1. Getopt::Long
1. Config::Tiny
1. Term::ReadLine
1. Term::ReadLine::Perl5

## Main Objectives
- [x] CRUD complete
- [DEPRECATED] Implement priority
- [x] Support PARA
    - Workspace, Project, Archive
- [x] Support Agile like structure
- [x] Due dates
- [x] Implement filter system
    - [x] Filter by project
    - [x] Filter by status
- [ ] Archive mechanism
    - [ ] Backup
    - [ ] Hide
- [x] Shorthand commands and long form
- [ ] Dont show old completed tasks (fcg time, and filter, use archive mechanism? automate?)
- [ ] Subtask mechanism

## Secondary Objectives
- [ ] Start and End date
- [ ] Calendar integration
- [x] Interactive editing (can get a reference for the todo
        before making an edit)
- [ ] Test the app
- [ ] implement creating and editing as ``` njatl -action=edit -index=idx -task='my todo' -duedate='due' -projects='project project'```


## Usage
Note that the shorthand uses are strict in formatting

- njatl create 'my todo @/due+project+project'
    - njatl -action=create -content='my todo @/due+project+project'

- njatl mark idx status
    - njatl -action=mark -index=idx -status=status

- njatl list (status+status+..., filter+filter+...)
    - njatl -action=list -filter=filters -status=statuses

_Passing 2 arguments indicates statuses then filters, Passing 1 argument indicates either statuses (if valid) **or** filters, Passing no arguments prints all entries_

- njatl delete idx
    - njatl -action=delete -index=idx

- njatl edit idx
    - njatl -action=edit -index=idx

## Bug Hunt
- [x] Make filters and status optional in list
- [x] Fix shorthands
- [ ] Differentiate status and filter seperator token
- [x] Use a better date and time api
- [ ] Do not interpolate '@' sign in file
