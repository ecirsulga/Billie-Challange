Requirement: 

Assignment
Take-home assignment 
 
Develop a queueable apex class which makes a callout to an endpoint and a LWC which 
displays the result. 
 
 
Description 
 
1.  Implement a queueable apex class that makes a callout to the 
https://eop0fqfuwjjx6lx.m.pipedream.net endpoint. As a result it should 
publish a platform event MostPublishedBooks__e containing a list of books sorted by 
the edition (the number of copies published), from highest to lowest, where the edition 
size exceeds 600,000 copies. 
2.  Implement a LWC which subscribes to the MostPublishedBooks__e event with 
lightning/empApi and displays the list of books in a user-friendly format. 
 
 
 
Expected output 
 
-  Github repository containing all the developed components 
-  Unit tests for the most critical functionality 
-  Instructions on how to deploy the solution into a scratch org or, ideally, how to create an 
unlocked package and install it into a scratch org 
-  Instructions on how to perform end-to-end testing in the scratch org 

---------------------------------------------------------------------------------------------------

Deployment steps for package:

- Create a Scratch org and sign in.
- Get your package with package manager. Go to link: https://login.salesforce.com/packaging/installPackage.apexp?p0=04tgL00000051wLQAQ use the password I provided on assignment completion.
- Or deploy all classes and metadata in force-app folder.

Steps for end-to-end testing:
- On App Launcher search for 'Most Published Books'.
- If you can't find it. Please assign yourself permission set : 'Most_Published_Books'.
- Use the buttons to enqueue queueable than the books will be published as Platform events and you will be able to see them in your LWC table.
