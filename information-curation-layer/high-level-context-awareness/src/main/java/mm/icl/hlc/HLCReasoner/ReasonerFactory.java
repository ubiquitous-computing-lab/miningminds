/**
* 
* Copyright [2016] [Claudia Villalonga & Muhammad Asif Razzaq]
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software distributed under 
* the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
*  ANY KIND, either express or implied.
*  See the License for the specific language governing permissions and limitations under the License.
*/
package mm.icl.hlc.HLCReasoner;

public class ReasonerFactory {
	enum Reasoning{HLC, LLC};
	
	private AbstractReasoner reasoner;
	
	public AbstractReasoner getReasoner(Reasoning type){
		switch(type){
		case HLC:
			reasoner = new HLCReasoner(null);
			break;
		case LLC:
			break;
		default:
			break;
		}
		
		return null;
	}
	
}
