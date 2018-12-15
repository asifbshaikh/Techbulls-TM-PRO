var app = angular.module('MyApp', []);
app.controller('MyController', function($scope, $http) {

	$scope.alert = false;
	$scope.validateTypes = function (type){
		if(type === "xml") { 
			$scope.alert = true; 
			$scope.alertHead = "XML not supported!"; 
			$scope.alertBody = "XML not supported for now, we will fix it soon"; 
		}
		else {
			$scope.alert = false; 
		}
	}

	$scope.isValidJson = function(){
		try {
        	JSON.parse($scope.inputData.input);
    	} catch (e) {
        	return false;
    	}
    	return true;
	}

    $scope.processRequest = function(){
    	if($scope.isValidJson()){
    		$http.post('process_request',$scope.inputData)
	    	.then( function(response){
	    		$scope.integrationMapping = response.data.integration_mapping;
	    		$scope.integrationCallsMeta = response.data.integration_calls_meta;
	    	},
	    	function(error){
	    		console.log(error);
	    	});	
    	}
    	else{
    		$scope.alert = true; 
    		$scope.alertHead = "JSON not valid !"; 
    		$scope.alertBody = "Please provide valid json and try again";
    	}
    	

    	


    	

    }
});