workspace {
    name "Social network"
    
    model {
        user = person "User"
        admin = person "Admin"

        socialNetwork = softwareSystem "Social network" {
            service = container "Service" {

                description "Handles users and messages"
                technology "FastAPI"

                userComponent = component "User component" {
                    description "Handles user authentication and management"
                    technology "FastAPI"
                }

                messageComponent = component "Message component" {
                    description "Handles sending and receiving messages"
                    technology "FastAPI"
                }
            }

            user -> service "Uses social network features via HTTP"
            admin -> socialNetwork "Manages system"
        }
    }
    
    views {
        systemContext socialNetwork {
            include *
            autolayout lr
        }

        container socialNetwork {
            include *
            autolayout lr
        }

        component service {
            include *
            autoLayout lr
        }

        dynamic socialNetwork "SendMessage" {
            user -> service "Sends message request"
            service -> user "Message saved"
        }
    }
}