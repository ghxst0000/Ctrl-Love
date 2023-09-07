# Ctrl-Love
<a name="readme-top"></a>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#what-is-ctrllove">What is Ctrl+Love?</a>
    </li>
    <li>
      <a href="#technologies-and-tools">Technologies and Tools</a>
      <ul>
        <li><a href="#backend">Backend</a></li>
        <li><a href="#frontend">Frontend</a></li>
        <li><a href="#additional">Additional</a></li>
      </ul>
    </li>
    <li><a href="#how-to-view-the-project">How to view the project</a></li>
		 <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <ul>
  </ol>
</details>

## What is Ctrl+Love?
Ctrl+Love is our andvanced project during our studies at CodeCool. It is a prototype dating application. To go beyond the landing page, users have to log in or sign up. After signing up with some basic credentials, those are saved in the database and then the user can provide additional personal information if they wish.

The user experience emulates that of Tinder's: users can view others' profiles, ordered by a matching algorithm and decide if they like or dislike them by "swiping" left or right.  In case of users mutually liking each other, an option to chat will become available [not yet implemented]. 

The project also features an automated containerization script that orchestrates the creation of two containers: one for the backend application and another for the SQL database. 
<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Technologies and Tools
### Backend
- ASP.NET Web Api
- Posgresql

### Frontend
- React
- TypeScript
- Vite

### Additional
- Docker
<p align="right">(<a href="#readme-top">back to top</a>)</p>

## How to view the project
### Prerequisites
- Linux system, either physical or virtual
- Docker installed
- Git installed (recommended)
### Installation
1. Clone the repository and its submodules
```sh
git clone --recurse-submodules git@github.com:ghxst0000/Ctrl-Love.git
```
2. Navigate to the project folder and run the deployment script
```sh
cd CtrlLove
./deploy.sh
```
3. Open localhost:8080 in a browser to view the application
<p align="right">(<a href="#readme-top">back to top</a>)</p>
