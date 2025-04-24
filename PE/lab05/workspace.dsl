workspace {
    name "Social network"
    
    model {
        user = person "User"
        admin = person "Admin"

        socialNetwork = softwareSystem "Social network" {
            service = container "Service" {

                description "Handles users, posts, and messages"
                technology "python"

                // HTTP API
                apiGateway = component "API Gateway" {
                description "Handles HTTP requests and routes them to the service"
                technology "Flask"
                }


                userComponent = component "User component" {
                    description "Handles user registration and retrieval"
                    technology "FastAPI/Flask"
                }

                postComponent = component "Post component" {
                    description "Handles post creation and retrieval"
                    technology "FastAPI/Flask"
                }

                messageComponent = component "Message component" {
                    description "Handles sending and receiving messages"
                    technology "FastAPI/Flask"
                }
            }

            // Database
            user_database = container "User Database" {
                technology "PostgreSQL"
            }

            user_cache = container "User Cache" {
                technology "Redis"
            }

            msg_database = container "Message Database" {
                technology "MongoDB"
            }

            // Relationships
            userComponent -> user_database "Reads/Writes data"
            userComponent -> user_cache "Reads/Writes data"
            messageComponent -> msg_database "Reads/Writes data"
            apiGateway -> userComponent
            apiGateway -> messageComponent
            apiGateway -> postComponent

            user -> apiGateway "Uses social network features via HTTP"
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
            service -> msg_database "Writes message"
            msg_database -> service "Message saved"
            service -> user "Message saved"
        }
    }
}
