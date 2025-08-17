global class PostInstallAssignPermset implements InstallHandler {
    
    global void onInstall(InstallContext context) {
        List<PermissionSet> permSets = [
            SELECT Id, Name 
            FROM PermissionSet 
            WHERE Name = 'Most_Published_Books_Access' 
            LIMIT 1
        ];
        
        PermissionSet permSet = permSets[0];
        
        List<Profile> sysAdminProfiles = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'System Administrator' 
            LIMIT 1
        ];
        
        Profile sysAdminProfile = sysAdminProfiles[0];
        
        List<User> sysAdminUsers = [
            SELECT Id 
            FROM User 
            WHERE ProfileId = :sysAdminProfile.Id 
            AND IsActive = true
        ];
        
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for(User u : sysAdminUsers) {
            assignments.add(new PermissionSetAssignment(
                PermissionSetId = permSet.Id,
                AssigneeId = u.Id
            ));
        }
        
    }
}