# CounterStrike Server

Spin up a Counterstrike 1.6 server in AWS to keep team entertained during Covid-19 Crisis

## Architecture

- Dedicated VPC
  - single public subnet
  - internet gateway
- single spot EC2 instance
  - brought up with ASG
  - fixed EIP
  - configured with integrated user-data script

## To Run
