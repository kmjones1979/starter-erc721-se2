import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys a contract named "Basecamp" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployERC721: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const owner = "0x007E483Cf6Df009Db5Ec571270b454764d954d95";
  const minter = "0x007E483Cf6Df009Db5Ec571270b454764d954d95";

  await deploy("ERC721", {
    from: deployer,
    proxy: {
      execute: {
        init: {
          methodName: "initialize",
          args: [owner, minter],
        },
      },
      proxyContract: "OpenZeppelinTransparentProxy",
    },
    log: true,
    autoMine: true,
  });

  const ERC721 = await hre.ethers.getContract<Contract>("ERC721", deployer);
  await ERC721.transferOwnership(owner);
};

export default deployERC721;

deployERC721.tags = ["ERC721"];
