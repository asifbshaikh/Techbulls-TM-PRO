var app = angular.module('MyApp', []);
app.controller('MyController', function($scope, $http) {

	$scope.alert = false;
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
    	}
    	

    	


    	

    }
});