import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys a contract named "AnonymousFeedback" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployAnonymousFeedback: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network sepolia`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` or `yarn account:import` to import your
    existing PK which will fill DEPLOYER_PRIVATE_KEY_ENCRYPTED in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("AnonymousFeedback", {
    from: deployer,
    // Contract constructor arguments
    args: [deployer],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const anonymousFeedback = await hre.ethers.getContract<Contract>("AnonymousFeedback", deployer);
  console.log("🎯 AnonymousFeedback contract deployed at:", await anonymousFeedback.getAddress());
  console.log("👤 Owner address:", await anonymousFeedback.owner());
  
  // Submit some sample feedback to test the contract
  console.log("📝 Submitting sample feedback...");
  
  // Submit positive feedback
  await anonymousFeedback.submitFeedback(
    "This is an amazing platform for anonymous feedback!",
    0, // POSITIVE
    "sample,test"
  );
  
  // Submit constructive feedback
  await anonymousFeedback.submitFeedback(
    "Consider adding more categories for better organization.",
    1, // CONSTRUCTIVE
    "suggestion,improvement"
  );
  
  // Submit idea
  await anonymousFeedback.submitFeedback(
    "What if we add a reputation system based on feedback quality?",
    2, // IDEAS
    "feature,reputation"
  );
  
  console.log("✅ Sample feedback submitted successfully!");
  console.log("📊 Total feedback count:", await anonymousFeedback.totalFeedbackCount());
};

export default deployAnonymousFeedback;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags AnonymousFeedback
deployAnonymousFeedback.tags = ["AnonymousFeedback"];
