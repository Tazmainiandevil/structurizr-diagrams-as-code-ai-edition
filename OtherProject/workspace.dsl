workspace "Other Software System" "Second example workspace, to show one folder per workspace." {

    model {
        user = person "User" "A customer who uses the web application."

        softwareSystem = softwareSystem "Other Software System" "Lets users view and update their data through a web application." {
            webapp = container "Web Application" "Serves the UI and handles user requests." "ASP.NET Core"
            database = container "Database" "Stores user data." "PostgreSQL" "Database"
        }

        user -> webapp "Views and updates data using" "HTTPS"
        webapp -> database "Reads from and writes to" "SQL/TCP"
    }

    views {
        systemContext softwareSystem "SystemContext" "System Context diagram for the Other Software System." {
            include *
            autoLayout lr
        }

        container softwareSystem "Containers" "Container diagram for the Other Software System." {
            include *
            autoLayout lr
        }

        styles {
            element "Software System" {
                background #c8c8c8
                color #000000
            }
            element "Container" {
                background #e6e6e6
                color #000000
            }
            element "Database" {
                shape cylinder
            }
            element "Person" {
                shape person
                background #0000ff
                color #ffffff
            }
        }
    }

    configuration {
        scope softwaresystem
    }

    properties {
        "structurizr.inspection.model.softwaresystem.documentation" "ignore"
        "structurizr.inspection.model.softwaresystem.decisions" "ignore"
    }
}
