workspace "Basic Software System" "Example workspace used in the Structurizr diagrams as code, AI edition blog post." {

    model {
        user = person "User" "A customer who uses the web application."

        softwareSystem = softwareSystem "Basic Software System" "Lets users view and update their data through a web application." {
            webapp = container "Web Application" "Serves the UI and handles user requests." "ASP.NET Core"
            database = container "Database" "Stores user data." "PostgreSQL" "Database"
        }

        user -> webapp "Views and updates data using" "HTTPS"
        webapp -> database "Reads from and writes to" "SQL/TCP"
    }

    views {
        systemContext softwareSystem "SystemContext" "System Context diagram for the Basic Software System." {
            include *
            autoLayout lr
        }

        container softwareSystem "Containers" "Container diagram for the Basic Software System." {
            include *
            autoLayout lr
        }

        styles {
            element "Software System" {
                background #0000ff
                color #ffffff
            }
            element "Container" {
                background #3d6fd9
                color #ffffff
            }
            element "Database" {
                shape cylinder
            }
            element "Person" {
                shape person
                background #00ffff
                color #000000
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
