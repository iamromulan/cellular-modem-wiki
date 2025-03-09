Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.


MBN (Mobile Broadband Network) profiles are configuration files used on Quectel cellular modems to define and manage the network connection parameters for different mobile carriers and service scenarios.

These profiles contain critical connection information such as:

1. APN (Access Point Name) settings (To be used in a PDP context)
2. Authentication parameters (username, password, method)
3. IP configuration (IPv4/IPv6)
4. QoS (Quality of Service) parameters
5. MCC/MNC (Mobile Country Code/Mobile Network Code) identifiers
6. Radio access technology preferences

MBN profiles allow modems to connect to specific cellular networks with the correct configuration parameters. Quectel modems can store multiple MBN profiles, enabling them to work across different carriers and regions without requiring manual reconfiguration.

When a Quectel modem is initialized or switches carriers, it loads the appropriate MBN profile to establish the connection correctly. These profiles can typically be managed through AT commands or Quectel's configuration tools.

For cellular IoT deployments, having the correct MBN profiles is essential for successful network registration and data connectivity.

## PDP Contexts

A Packet Data Protocol (PDP) context is a data structure used in cellular networks that defines a data session between a mobile device (like a Quectel modem) and the external packet data network (typically the internet).

1. **Definition**: It's essentially a logical connection or tunnel that carries data between your device and the external network.
    
2. **Components**: A PDP context contains several parameters:
    
    - PDP Type: Defines the network protocol (IPv4, IPv6, or dual-stack)
    - APN: The Access Point Name that identifies which external network to connect to
    - IP address: Assigned to your device for the data session
    - QoS (Quality of Service) profile: Defines traffic priorities and performance
    - Authentication parameters: Username, password, and method if required
3. **States**: A PDP context can be:
    
    - Inactive: Defined but not activated
    - Active: Fully established and ready for data transfer
    - Deactivating: In the process of being terminated
4. **Identifiers**: Each PDP context has a numeric identifier called a CID (Context ID) typically ranging from 1-16
    

## How PDP Contexts Work

When you want to connect to a data network:

1. Your device requests a PDP context activation via AT commands (like AT+CGDCONT for definition and AT+CGACT for activation)
2. The modem negotiates with the carrier network
3. If successful, the network assigns resources and an IP address
4. The connection is established and ready for data transfer

Many cellular modems support multiple simultaneous PDP contexts (with different CIDs), allowing connections to different services with varied parameters. For example, one context might connect to the internet while another connects to a private corporate network.

PDP contexts are fundamental to how mobile devices establish and maintain data connectivity in cellular networks.